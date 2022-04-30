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

    public GameObject m_crosshair;

    public void Reload()
    {
        if (m_isReloading) return;
        m_isReloading = true;
        StartCoroutine(ReloadAfterTime());
    }

    private IEnumerator ReloadAfterTime()
    {
        yield return new WaitForSeconds(m_reloadTime);

        Ray ray = Camera.main.ViewportPointToRay(new Vector3(0.5F, 0.5F, 0));
        RaycastHit hit;
        Vector3 targetPoint;
        if (Physics.Raycast(ray, out hit))
            targetPoint = hit.point;
        else
            targetPoint = ray.GetPoint(1000);

        GameObject l_arrow = CharacterControllerScript.GetArrowPool().GetNextElement();

        l_arrow.transform.position = m_arrowSpawnPoint.transform.position;
        l_arrow.transform.rotation = m_arrowSpawnPoint.transform.rotation;

        Rigidbody l_rb = l_arrow.GetComponent<Rigidbody>();
        l_rb.velocity = (targetPoint - m_arrowSpawnPoint.transform.position).normalized * m_Power;

        l_arrow.transform.SetParent(null);
        l_arrow.SetActive(true);

        m_isReloading = false;
    }

    public void FireArrow(float firepower)
    {
        if (m_isReloading) return;
        m_Power = firepower;
        Reload();
    }

    public bool IsReady()
    {
        return !m_isReloading;
    }
}
