using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Weapon : MonoBehaviour
{
    [SerializeField]
    private GameObject m_arrowSpawnPoint;

    [SerializeField]
    private Camera m_camera;

    private float m_Power;

    [SerializeField]
    private LayerMask m_layerMask;

    private bool m_hasGravity;

    /// <summary>
    /// Spawn the arrow and give it a velocity and a direction
    /// </summary>
    private void Shoot()
    {
        Ray ray = m_camera.ViewportPointToRay(new Vector3(0.5F, 0.5F, 0));
        RaycastHit hit;
        Vector3 targetPoint;
        if (Physics.Raycast(ray, out hit, m_layerMask))
            targetPoint = hit.point;
        else
            targetPoint = ray.GetPoint(1000);

        GameObject l_arrow = CharacterControllerScript.GetArrowPool().GetNextElement();

        l_arrow.transform.position = m_arrowSpawnPoint.transform.position;
        l_arrow.transform.rotation = m_arrowSpawnPoint.transform.rotation;

        l_arrow.transform.GetComponent<TrailRenderer>().Clear();

        Rigidbody l_rb = l_arrow.GetComponent<Rigidbody>();
        if (m_hasGravity)
        {
            l_rb.useGravity = true;
        }
        else
        {
            l_rb.useGravity = false;
        }

        if (Time.timeScale >= 0)
            l_rb.velocity = ((targetPoint - m_arrowSpawnPoint.transform.position).normalized * m_Power) / Time.timeScale;
        else
            l_rb.velocity = (targetPoint - m_arrowSpawnPoint.transform.position).normalized * m_Power;

        l_arrow.transform.SetParent(null);
        l_arrow.SetActive(true);
    }

    /// <summary>
    /// method that calls the arrow shooting and sets a velocity and gravity
    /// </summary>
    /// <param name="firepower"></param>
    public void FireArrow(float firepower, bool gravity)
    {
        m_Power = firepower;
        m_hasGravity = gravity;
        Shoot();
    }
}
