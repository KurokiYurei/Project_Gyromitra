using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Weapon : MonoBehaviour
{
    [SerializeField]
    [Range(0.2f, 0.5f)]
    private float m_reloadTime;

    [SerializeField]
    private Arrow m_arrowPrefab;

    [SerializeField]
    private GameObject m_arrowSpawnPoint;

    private Arrow m_currentArrow;

    private string m_enemyTag;

    private bool m_isReloading;

    private float m_Power;

    public GameObject m_crosshair;

    public void SetEnemyTag(string enemyTag)
    {
        m_enemyTag = enemyTag;
    }

    public void Reload()
    {
        if (m_isReloading || m_currentArrow != null) return;
        m_isReloading = true;
        StartCoroutine(ReloadAfterTime());
    }

    private IEnumerator ReloadAfterTime()
    {
        yield return new WaitForSeconds(m_reloadTime);
        /*
        m_currentArrow = Instantiate(m_arrowPrefab, m_arrowSpawnPoint.transform);
        m_currentArrow.transform.localPosition = Vector3.zero;
        */
        Ray ray = Camera.main.ViewportPointToRay(new Vector3(0.5F, 0.5F, 0));
        RaycastHit hit;
        Vector3 targetPoint;
        if (Physics.Raycast(ray, out hit))
            targetPoint = hit.point;
        else
            targetPoint = ray.GetPoint(1000);

        m_currentArrow = Instantiate(m_arrowPrefab, m_arrowSpawnPoint.transform.position, m_arrowSpawnPoint.transform.rotation);
        //m_currentArrow.transform.position = m_arrowSpawnPoint.transform.position;

        Rigidbody rb = m_currentArrow.GetComponent<Rigidbody>();
       
        //m_arrowSpawnPoint.transform.forward = l_forward;
        //rb.velocity = m_arrowSpawnPoint.transform.forward * m_Power;
        rb.velocity = (targetPoint - m_arrowSpawnPoint.transform.position).normalized * m_Power;

        m_currentArrow.SetEnemyTag(m_enemyTag);
        m_isReloading = false;
    }

    public void FireArrow(float firepower)
    {
        if (m_isReloading || m_currentArrow == null) return;
        // m_currentArrow.Fly(m_arrowSpawnPoint.transform.TransformDirection(Vector3.forward * firepower));
        m_currentArrow = null;
        m_Power = firepower;
        Reload();
    }

    public bool IsReady()
    {
        return (!m_isReloading || m_currentArrow != null);
    }
}
