using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Weapon : MonoBehaviour
{
    [SerializeField]
    [Range(0.2f, 0.5f)]
    private float m_reloadTime;

    [SerializeField]
    private GameObject m_arrowSpawnPoint;

    private bool m_isReloading;

    private float m_Power;

    [SerializeField]
    private GameObject m_crosshair;

    [SerializeField]
    private LayerMask m_layerMask;

    private bool m_hasGravity;

    /// <summary>
    /// The method that controlls the reload of the arrow
    /// </summary>
    public void StartReloading()
    {
        if (m_isReloading) return;
        m_isReloading = true;
        StartCoroutine(ReloadAfterTime());
    }

    /// <summary>
    /// Coroutine of the reload method and spawn the arrow with a direction
    /// </summary>
    /// <returns></returns>
    private IEnumerator ReloadAfterTime()
    {
        yield return new WaitForSecondsRealtime(m_reloadTime);

        Ray ray = Camera.main.ViewportPointToRay(new Vector3(0.5F, 0.5F, 0));
        RaycastHit hit;
        Vector3 targetPoint;
        if (Physics.Raycast(ray, out hit, m_layerMask))
            targetPoint = hit.point;
        else
            targetPoint = ray.GetPoint(1000);

        GameObject l_arrow = CharacterControllerScript.GetArrowPool().GetNextElement();

        l_arrow.transform.position = m_arrowSpawnPoint.transform.position;
        l_arrow.transform.rotation = m_arrowSpawnPoint.transform.rotation;

        Rigidbody l_rb = l_arrow.GetComponent<Rigidbody>();
        if (m_hasGravity)
        {
            l_rb.useGravity = true;
        }
        else
        {
            l_rb.useGravity = false;
        }

        if(Time.timeScale >= 0)
            l_rb.velocity = ((targetPoint - m_arrowSpawnPoint.transform.position).normalized * m_Power) / Time.timeScale;
        else
            l_rb.velocity = (targetPoint - m_arrowSpawnPoint.transform.position).normalized * m_Power;

        l_arrow.transform.SetParent(null);
        l_arrow.SetActive(true);

        m_isReloading = false;
    }

    /// <summary>
    /// method that fires the arrow
    /// </summary>
    /// <param name="firepower"></param>
    public void FireArrow(float firepower, bool gravity)
    {
        if (m_isReloading) return;
        m_Power = firepower;
        m_hasGravity = gravity;
        StartReloading();
    }
}
